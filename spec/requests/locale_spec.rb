require "rails_helper"

RSpec.describe "Locale selection", type: :request do
  describe "browser Accept-Language detection" do
    it "uses the best-weighted supported language from the header" do
      get root_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "ru-RU,ru;q=0.9,en;q=0.8" }
      expect(response.body).to include('lang="ru"')
    end

    it "falls back to the default locale when no supported language matches" do
      get root_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "fr-FR,fr;q=0.9" }
      expect(response.body).to include('lang="en"')
    end

    it "lets an explicit ?locale= param win over the header" do
      get root_path(locale: :ky), headers: { "HTTP_ACCEPT_LANGUAGE" => "ru" }
      expect(response.body).to include('lang="ky"')
    end

    it "sticks the detected locale in the session after the first visit" do
      get root_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "ru" }
      expect(response.body).to include('lang="ru"')

      # A later request without the header keeps the remembered locale.
      get root_path
      expect(response.body).to include('lang="ru"')
    end
  end

  describe "signed-in users" do
    let(:user) { create(:user, locale: "ky") }

    before do
      post session_path, params: { email_address: user.email_address, password: "password" }
    end

    it "prefers the user's saved locale over the browser header" do
      get root_path, headers: { "HTTP_ACCEPT_LANGUAGE" => "ru" }
      expect(response.body).to include('lang="ky"')
    end

    it "persists an explicit ?locale= choice to the account" do
      get root_path(locale: :ru)
      expect(response.body).to include('lang="ru"')
      expect(user.reload.locale).to eq("ru")
    end
  end
end
