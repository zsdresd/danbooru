﻿require 'test_helper'

module Sources
  class NicoSeigaTest < ActiveSupport::TestCase
    context "The source site for nico seiga" do
      setup do
        @site_1 = Sources::Strategies.find("http://lohas.nicoseiga.jp/o/910aecf08e542285862954017f8a33a8c32a8aec/1433298801/4937663")
        @site_2 = Sources::Strategies.find("http://seiga.nicovideo.jp/seiga/im4937663")
        @site_3 = Sources::Strategies.find("http://seiga.nicovideo.jp/watch/mg376206")
      end

      should "get the profile" do
        assert_equal("http://seiga.nicovideo.jp/user/illust/7017777", @site_1.profile_url)
        assert_equal("http://seiga.nicovideo.jp/user/illust/7017777", @site_2.profile_url)
      end

      should "get the artist name" do
        assert_equal("osamari", @site_1.artist_name)
        assert_equal("osamari", @site_2.artist_name)
      end

      should "get the artist commentary" do
        assert_equal("コジコジ", @site_2.artist_commentary_title)
        assert_equal("コジコジのドット絵\nこんなかわいらしい容姿で毒を吐くコジコジが堪らん（切実）", @site_2.artist_commentary_desc)
      end

      should "get the image url" do
        assert_match(/^http:\/\/lohas\.nicoseiga\.jp\/priv\//, @site_1.image_url)
        assert_match(/^http:\/\/lohas\.nicoseiga\.jp\/priv\//, @site_2.image_url)
      end

      should "get the canonical url" do
        assert_match(%r!\Ahttps?://lohas\.nicoseiga\.jp/priv/\h{40}/\d+/4937663!, @site_1.canonical_url)
        assert_match(%r!\Ahttps?://lohas\.nicoseiga\.jp/priv/\h{40}/\d+/4937663!, @site_2.canonical_url)
      end

      should "get the tags" do
        assert_not(@site_1.tags.empty?)
        first_tag = @site_1.tags.first
        assert_equal(["アニメ", "https://seiga.nicovideo.jp/tag/%E3%82%A2%E3%83%8B%E3%83%A1"], first_tag)

        assert_not(@site_2.tags.empty?)
        first_tag = @site_2.tags.first
        assert_equal(["アニメ", "https://seiga.nicovideo.jp/tag/%E3%82%A2%E3%83%8B%E3%83%A1"], first_tag)
      end

      should "convert a page into a json representation" do
        assert_nothing_raised do
          @site_1.to_h
        end
        assert_nothing_raised do
          @site_2.to_h
        end
      end

      should "work for a https://lohas.nicoseiga.jp/thumb/${id}i url" do
        site = Sources::Strategies.find("https://lohas.nicoseiga.jp/thumb/6844226i")

        full_image_url = %r!https?://lohas.nicoseiga.jp/priv/[a-f0-9]{40}/[0-9]+/6844226!
        assert_match(full_image_url, site.image_url)
        assert_match(full_image_url, site.canonical_url)
      end
    end

    context "normalizing for source" do
      should "normalize correctly" do
        source1 = "http://lohas.nicoseiga.jp/priv/3521156?e=1382558156&h=f2e089256abd1d453a455ec8f317a6c703e2cedf"
        source2 = "http://lohas.nicoseiga.jp/priv/b80f86c0d8591b217e7513a9e175e94e00f3c7a1/1384936074/3583893"
        source3 = "http://lohas.nicoseiga.jp/o/910aecf08e542285862954017f8a33a8c32a8aec/1433298801/4937663"
        source4 = "http://seiga.nicovideo.jp/image/source?id=3312222"

        assert_equal("https://seiga.nicovideo.jp/seiga/im3521156", Sources::Strategies.normalize_source(source1))
        assert_equal("https://seiga.nicovideo.jp/seiga/im3583893", Sources::Strategies.normalize_source(source2))
        assert_equal("https://seiga.nicovideo.jp/seiga/im4937663", Sources::Strategies.normalize_source(source3))
        assert_equal("https://seiga.nicovideo.jp/seiga/im3312222", Sources::Strategies.normalize_source(source4))
      end

      should "avoid normalizing unnormalizable urls" do
        bad_source = "https://seiga.nicovideo.jp"
        assert_equal(bad_source, Sources::Strategies.normalize_source(bad_source))
      end
    end
  end
end
