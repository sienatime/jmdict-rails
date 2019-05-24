Rails.application.config.to_prepare do
  Oga::XML::Entities.prepend CoreExtensions::Oga::Entities
end
