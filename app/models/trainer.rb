class Trainer < ActiveRecord::Base
	require 'nokogiri'
	require 'open-uri'

	after_initialize :init

	self.per_page = 50

	def init
		self.crawled_for_email ||= false
	end

	def self.to_csv(options = {})	
		CSV.generate(options) do |csv|
			csv << column_names
			all.each do |trainer|
				csv << trainer.attributes.values_at(*column_names)
			end
		end
	end

	def self.import_official(file)
		csv_text = File.read(file.path)
		csv = CSV.parse(csv_text, :headers => true)
		csv.each do |row|
			raw_data = row.to_hash
			if Trainer.where(siren: raw_data["siren"]).empty?
				Trainer.create!(raw_data.slice("siren", "sigle", "effectif"))
			end
		end
	end

	def self.import_societe(file)
		# open CSV file
		csv_text = File.read(file.path)
		csv = CSV.parse(csv_text, :headers => true, quote_char: "\x00")

		# read rows
		csv.each do |row|
			raw_data = row.to_hash
			# parse "rens_jur" into Dénomination, Présence d'adresse, Adresse, Code Postal, Présence du téléphone, Siren, Activité, Forme juridique, Type de date de création, Date de création
			rens_jur = /Dénomination (.*?)( Adresse (.*?(\d{5}).*?)|)( Téléphone .*?|) SIREN (.*?) SIRET .*? Description de l'activité de l'entreprise (.*?) Forme juridique (.*?) (Date création entreprise|Date immatriculation RCS) (.*?) Tranche/.match(raw_data["rens_jur"])
			if rens_jur
				trainer = Trainer.where(siren: rens_jur[6]).first
				trainer.update(denomination: rens_jur[1])
				trainer.update(adresse: rens_jur[3])
				trainer.update(code_postal: rens_jur[4])
				trainer.update(activite: rens_jur[7])
				trainer.update(forme_juridique: rens_jur[8])
				trainer.update(date_de_creation: rens_jur[10])

				trainer.update(lien_societe: raw_data["_pageUrl"])

				# parse "dirigeant" into sexe_dirigeant, nom_dirigeant
				dirigeant = /Depuis.*?\d{4} (M|MME) (.*?) En savoir plus/.match(raw_data["dirigeant"])
				if dirigeant
					trainer.update(sexe_dirigeant: dirigeant[1])
					trainer.update(nom_dirigeant: dirigeant[2])
				end
			end
		end
	end

	def self.crawl_for_emails(crawls_number)
		i = 1
		validated_emails_count = 0

		# list OFs that have a dirigeant, that haven't already been crawled, and that are in Paris in priority
		trainers = Trainer.where.not(nom_dirigeant: nil, crawled_for_email: true).select("*, CASE WHEN trainers.code_postal like '75%' THEN 0 ELSE 1 END AS trainers_order").order("trainers_order ASC").limit(1000)

		while i <= crawls_number.to_i do
			trainer = trainers[i-1]

			# track progress in console
			logger.info "Request #{i} is SIREN #{trainer.siren}"

			# find the domain of the company using Bing's first search result on query 'sigle'
			domain = trainer.find_domain

			unless domain.nil?
				# build email address by removing accents, replacing spaces by dots, and using "@domain"
				email = I18n.transliterate(trainer.nom_dirigeant).gsub(/ /,'.')+'@'+domain

				# test email address with QuickEmailVerificationAPI
				if try_address(email) == 'valid'
					trainer.email_dirigeant = email
					validated_emails_count+=1
				end
			end

			# remember that OF has been crawled, save, and move to next
			trainer.crawled_for_email = true
			trainer.save
			i+=1
		end



		return validated_emails_count
	end

	# extracts the domain name using BING's first search result.
	# sends nil if can't find it.
	def find_domain
		doc = Nokogiri::HTML(open('http://www.bing.com/search?' + {q: self.sigle}.to_query))
		url_block = doc.css('.b_algo cite').first

		return nil if url_block.nil?

		md = /\.(.*?\.[[:alpha:]]{2,4})($|\/| ›)/.match(url_block.content)

		return nil if md.nil?

		return md[1]
	end

	def self.try_address(email)
		# call QuickEmailVerification API
		begin
			doc = open("http://api.quickemailverification.com/v1/verify?apikey=09f7ff4254cb0fca02a614bd12611ed94585ab4fa90b04a7476e31c8381c&email=" + email)
		rescue Net::ReadTimeout
			logger.info "QuickEmailVerification TimeOut"
			return "TimeOut"
		end

		
		# convert to hash
		response = JSON.parse(doc.read)

		# read result
		return response['result']
	end
end
