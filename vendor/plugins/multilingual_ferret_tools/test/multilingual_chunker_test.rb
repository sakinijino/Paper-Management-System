require 'rubygems'
require 'test/unit'
require File.dirname(__FILE__) + '/../lib/multilingual_chunker'
require 'active_support'

class MultilingualFerretTools::ChunkerTest < Test::Unit::TestCase
  def test_classify_all_latin
    assert_equal MultilingualFerretTools::Chunker.classify(@@LATIN_STRING), :latin
  end
  
  def test_classify_all_non_latin
    assert_equal MultilingualFerretTools::Chunker.classify(@@NON_LATIN_STRING), :non_latin
  end
  
  def test_classify_mixed
    assert_equal MultilingualFerretTools::Chunker.classify(@@LATIN_STRING + @@LATIN_WHITESPACE + @@NON_LATIN_STRING), :mixed
    assert_equal MultilingualFerretTools::Chunker.classify(@@LATIN_STRING + @@NON_LATIN_WHITESPACE + @@NON_LATIN_STRING), :mixed
  end
  
  def test_classify_latin_whitespace
    assert_equal MultilingualFerretTools::Chunker.classify(@@LATIN_WHITESPACE), :latin_whitespace
  end

  def test_classify_non_latin_whitespace
    assert_equal MultilingualFerretTools::Chunker.classify(@@NON_LATIN_WHITESPACE), :non_latin_whitespace
  end
  
  def test_chunk_all_latin_with_discarded_whitespace
    c = MultilingualFerretTools::Chunker.new @@LATIN_STRING, :whitespace => :discard
    assert_latin_string_words c
  end
  
  def test_chunk_all_latin_with_combined_whitespace
    c = MultilingualFerretTools::Chunker.new @@LATIN_STRING, :whitespace => :combine
    assert_latin_string c
  end
  
  def test_chunk_all_latin_with_reported_whitespace
    c = MultilingualFerretTools::Chunker.new @@LATIN_STRING, :whitespace => :report
    assert_latin_string_words c, 0, true
  end

  def test_chunk_all_non_latin_single_word
    c = MultilingualFerretTools::Chunker.new @@NON_LATIN_STRING, :whitespace => :discard
    assert_non_latin_string c
  end
  
  def test_chunk_all_non_latin_with_discarded_whitespace
    c = MultilingualFerretTools::Chunker.new @@NON_LATIN_STRING + @@NON_LATIN_WHITESPACE + @@NON_LATIN_STRING, :whitespace => :discard
    n = assert_non_latin_string c
    assert_non_latin_string c, n + @@NON_LATIN_WHITESPACE.length
  end
  
  def test_chunk_all_non_latin_with_reported_whitespace
    c = MultilingualFerretTools::Chunker.new @@NON_LATIN_STRING + @@NON_LATIN_WHITESPACE + @@NON_LATIN_STRING, :whitespace => :report
    n = assert_non_latin_string c
    n = assert_non_latin_whitespace c, n
    assert_non_latin_string c, n
  end

  def test_chunk_mixed_with_discarded_whitespace
    c = MultilingualFerretTools::Chunker.new @@MIXED_STRING, :whitespace => :discard
    n = assert_latin_string_words c
    n = assert_non_latin_string c, n + @@LATIN_WHITESPACE.length
    assert_latin_string_words c, n + @@NON_LATIN_WHITESPACE.length
  end
  
  def test_chunk_mixed_with_combined_whitespace
    c = MultilingualFerretTools::Chunker.new @@MIXED_STRING, :whitespace => :combine
    n = assert_latin_string c, 0, true
    n = assert_non_latin_string c, n, true
    assert_latin_string c, n
  end
  
  def test_chunk_mixed_with_reported_whitespace
    c = MultilingualFerretTools::Chunker.new @@MIXED_STRING, :whitespace => :report
    n = assert_latin_string_words c, 0, true
    n = assert_latin_whitespace c, n
    n = assert_non_latin_string c, n
    n = assert_non_latin_whitespace c, n
    assert_latin_string_words c, n, true
  end

  private
  
  def assert_latin_string_words(chunker, start=0, expect_whitespace_chunks=false)
    accumulated_length = 0
    end_index = 0
    
    @@LATIN_WORDS.each_with_index do |w, i|
      chunk = chunker.next
      
      assert_equal chunk[0], w
      assert_equal chunk[1], :latin
      assert_equal chunk[2], start + accumulated_length
      assert_equal chunk[3], start + accumulated_length + w.length - 1
      
      accumulated_length += w.length
      accumulated_length += @@LATIN_WHITESPACE.length if !expect_whitespace_chunks
      end_index = chunk[3] + 1
      
      if i < @@LATIN_WORDS.length - 1 and expect_whitespace_chunks
        end_index = assert_latin_whitespace(chunker, chunk[3] + 1)
        accumulated_length += @@LATIN_WHITESPACE.length
      end
    end
    
    end_index
  end
  
  def assert_latin_string(chunker, start=0, trailing_whitespace=false)
    expected = trailing_whitespace ? @@LATIN_STRING + @@LATIN_WHITESPACE : @@LATIN_STRING

    chunk = chunker.next
    assert_equal chunk[0], expected
    assert_equal chunk[1], :latin
    assert_equal chunk[2], start
    assert_equal chunk[3], start + expected.length - 1
    chunk[3] + 1
  end
  
  def assert_latin_whitespace(chunker, start)
    chunk = chunker.next
    assert_equal chunk[0], @@LATIN_WHITESPACE
    assert_equal chunk[1], :latin_whitespace
    assert_equal chunk[2], start
    assert_equal chunk[3], start + @@LATIN_WHITESPACE.length - 1
    chunk[3] + 1
  end
  
  def assert_non_latin_string(chunker, start=0, trailing_whitespace=false)
    expected = trailing_whitespace ? @@NON_LATIN_STRING + @@NON_LATIN_WHITESPACE : @@NON_LATIN_STRING
    chunk = chunker.next
    assert_equal chunk[0], expected
    assert_equal chunk[1], :non_latin
    assert_equal chunk[2], start
    assert_equal chunk[3], start + expected.length - 1
    chunk[3] + 1
  end
  
  def assert_non_latin_whitespace(chunker, start)
    chunk = chunker.next
    assert_equal chunk[0], @@NON_LATIN_WHITESPACE
    assert_equal chunk[1], :non_latin_whitespace
    assert_equal chunk[2], start
    assert_equal chunk[3], start + @@NON_LATIN_WHITESPACE.length - 1
    chunk[3] + 1
  end
    
  def assert_next_chunk(chunker, str, type, start, _end)
    chunk = chunker.next
    assert_equal chunk[0], str
    assert_equal chunk[1], type
    assert_equal chunk[2], start
    assert_equal chunk[3], _end
  end

  @@LATIN_WORDS = [ "foo", "bar", "bro", "baz"]
  @@LATIN_WHITESPACE = " "
  @@LATIN_STRING = @@LATIN_WORDS.join(@@LATIN_WHITESPACE)
  
  @@NON_LATIN_STRING = "\xe6\x82\xaa\xe3\x81\x9d\xe3\x81\x86"
  @@NON_LATIN_WHITESPACE = "\xe3\x80\x80"
  
  @@MIXED_STRING = @@LATIN_STRING + @@LATIN_WHITESPACE + @@NON_LATIN_STRING + @@NON_LATIN_WHITESPACE + @@LATIN_STRING
end
