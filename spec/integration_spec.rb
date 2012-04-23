require 'spec_helper'

describe Article do
  describe ".create" do
    it "builds valid arrays" do
      article = Article.create(:languages => ["English", "German"], :author_ids => [1,2,3])
      article.reload
      article.languages_before_type_cast.should == "{English,German}"
      article.languages.should == ["English", "German"]
      article.author_ids_before_type_cast.should == "{1,2,3}"
      article.author_ids.should == [1,2,3]
    end

    it "escapes single quotes correctly" do
      article = Article.create(:languages => ["English", "Ger'man"])
      article.reload
      article.languages_before_type_cast.should == "{English,Ger''man}"
      article.languages.should == ["English", "Ger'man"]
    end

    it "escapes double quotes correctly" do
      article = Article.create(:languages => ["English", "Ger\"man"])
      article.reload
      article.languages_before_type_cast.should == "{English,\"Ger\\\"man\"}"
      article.languages.should == ["English", "Ger\"man"]
    end

    it "handles commas correctly" do
      article = Article.create(:languages => ["English", "Ger,man"])
      article.reload
      article.languages_before_type_cast.should == "{English,\"Ger,man\"}"
      article.languages.should == ["English", "Ger,man"]
    end

    it "handles backslashes correctly" do
      article = Article.create(:languages => ["\\","\""])
      article.reload
      article.languages_before_type_cast.should == '{"\\\\","\\""}'
      article.languages.should == ["\\","\""]
    end
  end

  describe ".update" do
    before(:each) do
      @article = Article.create
    end

    it "builds valid arrays" do
      @article.languages = ["English", "German"]
      @article.save
      @article.reload
      @article.languages_before_type_cast.should == "{English,German}"
    end

    it "escapes single quotes correctly" do
      @article.languages = ["English", "Ger'man"]
      @article.save
      @article.reload
      @article.languages_before_type_cast.should == "{English,Ger'man}"
      @article.languages.should == ["English", "Ger'man"]
    end

    it "escapes double quotes correctly" do
      @article.languages = ["English", "Ger\"man"]
      @article.save
      @article.reload
      @article.languages_before_type_cast.should == "{English,\"Ger\\\"man\"}"
      @article.languages.should == ["English", "Ger\"man"]
    end

    it "handles commas correctly" do
      @article.languages = ["English", "Ger,man"]
      @article.save
      @article.reload
      @article.languages_before_type_cast.should == "{English,\"Ger,man\"}"
      @article.languages.should == ["English", "Ger,man"]
    end

    it "handles backslashes correctly" do
      @article.languages = ["\\","\""]
      @article.save
      @article.reload
      @article.languages_before_type_cast.should == '{"\\\\","\\""}'
      @article.languages.should == ["\\","\""]
    end
  end

end
