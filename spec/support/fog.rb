Fog.mock!

def fog_directory
  ENV['AWS_FOG_DIRECTORY']
end

connection = ::Fog::Storage.new(
  :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
  :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],
  :provider               => 'AWS'
)

connection.directories.create(:key => fog_directory)

