require 'spec_helper_acceptance'

describe 'exiscan' do
  before(:all) do
    @manifest = <<-PP
      class {
        'exiscan':
          sa_bayes_sql_dsn      => 'sa_bayes_sql_dsn_value',
          sa_bayes_sql_username => 'sa_bayes_sql_username_value',
          greylist_dsn          => 'greylist_dsn',
          greylist_sql_username => 'greylist_sql_username_value',
      }
    PP
    @result = apply_manifest_on default, @manifest, accept_all_exit_codes: true, expect_changes: true
  end

  it 'runs with changes' do
    expect(@result.exit_code).to eq 2
  end
end
