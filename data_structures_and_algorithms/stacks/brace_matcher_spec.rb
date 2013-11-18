require 'rspec'

class Stack
  def initialize
    @stack = Array.new
  end

  def pop
    @stack.pop
  end

  def push(el)
    @stack.push(el)
  end

  def size
    @stack.size
  end
end

class BraceMatcher
  BRACES = {
    '(' => ')',
    '[' => ']',
    '{' => '}'
  }

  def check_matching(str)
    stack = Stack.new
    str.chars.each do |ch|
      # handle open braces
      stack.push(ch) if BRACES.keys.include?(ch)
      # handle closing braces
      if BRACES.values.include?(ch)
        return false if BRACES[stack.pop] != ch
      end
    end
    return stack.size == 0 # Reject dangling open braces
  end
end

describe 'brace matching' do
  subject(:matcher) { BraceMatcher.new }

  it 'accepts blank input' do
    matcher.check_matching('').should == true
  end
  it 'accepts matching parens' do
    matcher.check_matching('()').should == true
  end
  it 'rejects one extra closing paren' do
    matcher.check_matching('())').should == false
  end
  it 'rejects one extra open paren' do
    matcher.check_matching('(()').should == false
  end
  it 'accepts multiple brace types' do
    matcher.check_matching('[{}]').should == true
    matcher.check_matching('{()}').should == true
  end
  it 'rejects misordered multiple brace types' do
    matcher.check_matching('([)]').should == false
  end
  it 'rejects backwards parens' do
    matcher.check_matching(')(').should == false
  end
end
