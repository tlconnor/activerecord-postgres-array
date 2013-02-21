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

    it 'does not interfere with YAML serialization' do
      article = Article.create!(
        :languages => ['a','b'],
        :author_ids => [1, 2, 3],
        :prices => [1.1, 2.2, 3.3],
        :serialized_column => {:a => 1, :b => 2}
      )
      article.reload

      article.serialized_column.should == {:a => 1, :b => 2}
      article.languages.should == ['a', 'b']
      article.author_ids.should == [1, 2, 3]
      article.prices.should == [1.1, 2.2, 3.3]
    end

    it 'does not interfere with hstore serialization' do
      article = Article.create!(
        :languages => ['a','b'],
        :author_ids => [1, 2, 3],
        :prices => [1.1, 2.2, 3.3],
        :hstore_column => {:a => 1, :b => 2}
      )
      article.reload

      article.hstore_column['a'].to_s.should == '1'
      article.hstore_column['b'].to_s.should == '2'
      article.languages.should == ['a', 'b']
      article.author_ids.should == [1, 2, 3]
      article.prices.should == [1.1, 2.2, 3.3]
    end
  end

  describe ".update" do
    before(:each) do
      @article = Article.create
    end

    it "builds valid arrays" do
      @article.languages = ["English", "German"]
      @article.prices = [1.2, 1.3]
      @article.save
      @article.reload
      @article.languages_before_type_cast.should == "{English,German}"
      @article.prices_before_type_cast.should == "{1.2,1.3}"
      @article.languages.should == ["English", "German"]
      @article.prices.should == [1.2, 1.3]
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

    it 'is able to be contatenated with new arrays' do
      article = Article.new
      article.languages = (article.languages || []) + ['a', 'b', 'c']
      article.save!
      article.reload
      article.languages.should == ['a', 'b', 'c']

      article.languages += ['d']
      article.save!
      article.reload
      article.languages.should == ['a', 'b', 'c', 'd']
    end
  end
end
