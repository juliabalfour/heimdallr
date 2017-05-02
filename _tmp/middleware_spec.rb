describe 'Middleware' do
  describe 'JWT middleware' do

    it 'returns an error when the authorization header is missing' do
      query(query: { test: true })
      expect(last_response.status).to eq(401)
    end

    it 'returns an error when the authorization header is incorrect' do
      header 'Authorization', 'Bearer invalid_tokens_go_down_the_hole'
      query(query: { test: true })
      expect(last_response.status).to eq(401)
      ap last_response.body
    end
  end
end
