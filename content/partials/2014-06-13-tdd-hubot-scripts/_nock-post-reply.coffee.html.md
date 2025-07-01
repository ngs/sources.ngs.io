nock('http://www.browserstack.com')
  .post('/screenshots')
  .reply 200, job_id: 'abcd1234' # JSON response
