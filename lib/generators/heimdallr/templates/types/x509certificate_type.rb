module Types
  X509CertificateType = GraphQL::ScalarType.define do
    # noinspection RubyArgCount
    name 'X509Certificate'
    description 'A valid x509 certificate string.'

    coerce_input ->(value, _ctx) do
      certificate = begin
        OpenSSL::X509::Certificate.new(value)
      rescue
        nil
      end

      certificate
    end

    coerce_result ->(value, _ctx) { value.to_s }
    default_scalar true
  end
end
