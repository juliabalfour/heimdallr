require 'jwt'
require 'openssl'

describe 'jwt token test' do
  let(:uuid) { SecureRandom.uuid }

  let(:rsa) { OpenSSL::PKey::RSA.generate(2048) }

  let(:header_fields) { { app: uuid } }

  let(:payload) do
    {
      data: {
        scopes: %w[events:all venues:create venues:delete]
      },
      aud: 'Event API'
    }
  end

  let(:algorithm) { 'RS512' }

  it 'puts the lotion on its skin or it gets the hose again' do
    encoded = JWT.encode(payload, rsa, algorithm, header_fields)
    public = rsa.public_key

    decoded = JWT.decode(encoded, nil, true) do |header|
      # header.fetch('app')
      public
    end

    puts '*' * 150
    ap public.to_text
    puts '*' * 150
    ap encoded
    puts '*' * 150
    ap decoded

    # rsa_key = OpenSSL::PKey::RSA.new(2048)
    # ap rsa_key.to_s
    #
    # cipher = OpenSSL::Cipher::Cipher.new('des3')
    # private_key = rsa_key.to_pem(cipher, 'password')
    # puts '*' * 200
    # ap private_key
  end
end
