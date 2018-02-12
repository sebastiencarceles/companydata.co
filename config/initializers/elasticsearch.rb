
# frozen_string_literal: true

Searchkick.aws_credentials = {
  access_key_id: Figaro.env.AWS_ACCESS_KEY_ID,
  secret_access_key: Figaro.env.AWS_SECRET_ACCESS_KEY,
  region: Figaro.env.AWS_REGION
}
