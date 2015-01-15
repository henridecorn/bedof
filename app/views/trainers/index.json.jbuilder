json.array!(@trainers) do |trainer|
  json.extract! trainer, :id, :siren, :sigle
  json.url trainer_url(trainer, format: :json)
end
