require 'minitest/autorun'

def require_app(required)
  require_relative "../../app/#{required}"
end

class Id58TestBase < MiniTest::Test
  def initialize(arg)
    @_id58 = nil
    @_name58 = nil
    super
  end

  @@args = (ARGV.sort.uniq - ['--']) # eg 2m4
  @@seen_ids = []
  @@timings = {}

  # - - - - - - - - - - - - - - - - - - - - - -

  # :nocov:
  def self.test(id58_suffix, *lines, &test_block)
    src = test_block.source_location
    src_file = File.basename(src[0])
    src_line = src[1].to_s
    id58 = checked_id58(id58_suffix, lines)
    return unless @@args === [] || @@args.any? { |arg| id58.include?(arg) }

    name58 = lines.join(space = ' ')
    execute_around = lambda {
      ENV['ID58'] = id58
      @_id58 = id58
      @_name58 = name58
      id58_setup
      begin
        t1 = Time.now
        instance_eval(&test_block)
        t2 = Time.now
        @@timings[id58 + ':' + src_file + ':' + src_line + ':' + name58] = (t2 - t1)
      ensure
        puts $!.message unless $!.nil?
        id58_teardown
      end
    }
    name = "id58 '#{id58_suffix}',\n'#{name58}'"
    define_method("test_\n#{name}".to_sym, &execute_around)
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  ObjectSpace.define_finalizer(self, proc {
    slow = @@timings.select { |_name, secs| secs > 0.000 }
    sorted = slow.sort_by { |_name, secs| -secs }.to_h
    size = [sorted.size, 10].min
    puts
    puts 'Slowest tests are...' unless sorted.empty?
    sorted.each_with_index do |(name, secs), index|
      puts format('%3.4f - %-72s', secs, name)
      break if index === size
    end
  })

  # - - - - - - - - - - - - - - - - - - - - - -

  ID58_ALPHABET = %w[
    0 1 2 3 4 5 6 7 8 9
    A B C D E F G H J K L M N P Q R S T U V W X Y Z
    a b c d e f g h j k l m n p q r s t u v w x y z
  ].join.freeze

  def self.id58?(s)
    s.is_a?(String) &&
      s.chars.all? { |ch| ID58_ALPHABET.include?(ch) }
  end

  def self.checked_id58(id58_suffix, lines)
    method = 'def self.id58_prefix'
    pointer = ' ' * method.index('.') + '!'
    pointee = ['', pointer, method, '', ''].join("\n")
    pointer.prepend("\n\n")
    raise "#{pointer}missing#{pointee}" unless respond_to?(:id58_prefix)
    raise "#{pointer}empty#{pointee}" if id58_prefix === ''
    raise "#{pointer}not id58#{pointee}" unless id58?(id58_prefix)

    method = "test '#{id58_suffix}',"
    pointer = ' ' * method.index("'") + '!'
    proposition = lines.join(space = ' ')
    pointee = ['', pointer, method, "'#{proposition}'", '', ''].join("\n")
    id58 = id58_prefix + id58_suffix
    pointer.prepend("\n\n")
    raise "#{pointer}empty#{pointee}" if id58_suffix === ''
    raise "#{pointer}not id58#{pointee}" unless id58?(id58_suffix)
    raise "#{pointer}duplicate#{pointee}" if @@seen_ids.include?(id58)
    raise "#{pointer}overlap#{pointee}" if id58_prefix[-2..-1] === id58_suffix[0..1]

    @@seen_ids << id58
    id58
  end

  # - - - - - - - - - - - - - - - - - - - - - -

  def id58_setup; end

  def id58_teardown; end

  # - - - - - - - - - - - - - - - - - - - - - -

  def id58
    @_id58
  end

  def name58
    @_name58
  end
  # :nocov:
end
