require "spec_helper"

describe MembersController do
  describe "routing" do

    it "routes to #index" do
      expect(get("/members")).to route_to("members#index")
    end

    it "routes to #new" do
      expect(get("/members/new")).to route_to("members#new")
    end

    it "routes to #show" do
      expect(get("/members/1")).to route_to("members#show", :id => "1")
      expect(get("/members/john-smith")).to route_to("members#show", :id => "john-smith")
    end

    it "routes to #edit" do
      expect(get("/members/1/edit")).to route_to("members#edit", :id => "1")
      expect(get("/members/john-smith/edit")).to route_to("members#edit", :id => "john-smith")
    end

    it "routes to #create" do
      expect(post("/members")).to route_to("members#create")
    end

    it "routes to #update" do
      expect(put("/members/1")).to route_to("members#update", :id => "1")
      expect(put("/members/john-smith")).to route_to("members#update", :id => "john-smith")
    end

    it "routes to #destroy" do
      expect(delete("/members/1")).to route_to("members#destroy", :id => "1")
      expect(delete("/members/john-smith")).to route_to("members#destroy", :id => "john-smith")
    end

  end
end
