require 'rubygems'
require 'test/unit'
require File.dirname(__FILE__) + '/../init'
require 'active_support'

class MultilingualFerretTools::AnalyzerTest < Test::Unit::TestCase
  def test_all_latin
    a = MultilingualFerretTools::Analyzer.new
    ts = a.token_stream 'foo', 'now is the time'
    
    assert_next_token ts, 'now', 0, 3
    assert_next_token ts, 'time', 11, 15
  end
  
  def test_all_non_latin
    a = MultilingualFerretTools::Analyzer.new
    ts = a.token_stream 'foo', "\xe6\x82\xaa\xe3\x81\x9d\xe3\x81\x86"
    
    assert_next_token ts, "\xe6\x82\xaa", 0, 3
    assert_next_token ts, "\xe3\x81\x9d", 3, 6
    assert_next_token ts, "\xe3\x81\x86", 6, 9
  end
  
  def test_mixed
    a = MultilingualFerretTools::Analyzer.new
    ts = a.token_stream 'foo', "\xe6\x82\xaa\xe3\x81\x9d\xe3\x81\x86 foo and bar \xe6\x82\xaa\xe3\x81\x9d\xe3\x81\x86"

    assert_next_token ts, "\xe6\x82\xaa", 0, 3
    assert_next_token ts, "\xe3\x81\x9d", 3, 6
    assert_next_token ts, "\xe3\x81\x86", 6, 9
    assert_next_token ts, 'foo', 10, 13
    assert_next_token ts, 'bar', 18, 21
    assert_next_token ts, "\xe6\x82\xaa", 22, 25
    assert_next_token ts, "\xe3\x81\x9d", 25, 28
    assert_next_token ts, "\xe3\x81\x86", 28, 31
  end
  
  private
  
  def assert_next_token(ts, text, start, _end)
    token = ts.next
    assert_equal token.text, text
    assert_equal token.start, start
    assert_equal token.end, _end
  end
end

