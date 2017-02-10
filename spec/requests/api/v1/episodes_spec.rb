# frozen_string_literal: true

describe "Api::V1::Episodes" do
  let(:access_token) { create(:oauth_access_token) }
  let!(:work) { create(:work, :with_current_season, :with_episode) }

  describe "GET /v1/episodes" do
    before do
      get api("/v1/episodes", access_token: access_token.token)
    end

    context "when added no parameters" do
      it "responses 200" do
        expect(response.status).to eq(200)
      end

      it "gets episode info" do
        episode = work.episodes.first
        expected_hash = {
          "id" => episode.id,
          "number" => episode.raw_number,
          "number_text" => episode.number,
          "sort_number" => episode.sort_number,
          "title" => episode.title,
          "records_count" => 0,
          "prev_episode" => nil,
          "next_episode" => nil,
          "work" => {
            "id" => work.id,
            "title" => work.title,
            "title_kana" => work.title_kana,
            "media" => "tv",
            "media_text" => "TV",
            "season_name" => "2017-winter",
            "season_name_text" => "2017年冬",
            "released_on" => "2012-04-05",
            "released_on_about" => "2012年",
            "official_site_url" => "http://example.com",
            "wikipedia_url" => "http://wikipedia.org",
            "twitter_username" => "precure_official",
            "twitter_hashtag" => "precure",
            "episodes_count" => 1,
            "watchers_count" => 0
          }
        }
        expect(json["episodes"][0]).to include(expected_hash)
        expect(json["total_count"]).to eq(1)
        expect(json["next_page"]).to eq(nil)
        expect(json["prev_page"]).to eq(nil)
      end
    end
  end
end
