Before do
  stub_request(:post, %r{https://webhook\.site/test})
    .to_return(status: 200, body: '{"success": true}', headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, %r{https://webhook\.site/new})
    .to_return(status: 200, body: '{"success": true}', headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, %r{https://webhook\.site/old})
    .to_return(status: 200, body: '{"success": true}', headers: { 'Content-Type' => 'application/json' })

  stub_request(:post, %r{https://webhook\.site/invalid})
    .to_return(status: 500, body: '{"error": "Internal Server Error"}', headers: { 'Content-Type' => 'application/json' })
end
