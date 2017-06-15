RSpec.describe 'Application Management' do
  it 'creates a new application using GraphQL' do
    query = <<-GRAPHQL
    {
      createApplication(input: {
        name: "Unicorns & Rainbows",
        scopes: ["unicorn:create", "unicorn:update", "unicorn:hug", "unicorn:ride", "rainbow:create", "rainbow:obliterate"],
        algorithm: RS256
      }) {
        application {
          id
          name
          key
        }
      }
    }
    GRAPHQL

    graphql(query: query)
    expect(response.content_type).to eq('application/json')
  end
end
