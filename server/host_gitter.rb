
class HostGitter

  def initialize(parent)
    @parent = parent
  end

  # queries

  attr_reader :parent

  def setup(path, user_name, user_email)
    shell.cd_exec(path,
      'git init --quiet',
      "git config user.name #{quoted(user_name)}",
      "git config user.email #{quoted(user_email)}"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def diff(path, n, m)
    options = [
      '--ignore-space-at-eol',
      '--find-copies-harder',
      "#{n}",
      "#{m}",
      'sandbox'
    ].join(space = ' ')
    output_of(shell.cd_exec(path, "git diff #{options}"))
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def rm(path, filename)
    shell.cd_exec(path, "git rm #{quoted(filename)}")
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def add(path, filename)
    shell.cd_exec(path, "git add #{quoted(filename)}")
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def commit(path, tag)
    shell.cd_exec(path,
      "git commit -a -m #{tag} --quiet",
      'git gc --auto --quiet',
      "git tag -m '#{tag}' #{tag} HEAD"
    )
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  def XXX_show(path, options)
    output_of(shell.cd_exec(path, "git show #{options}"))
  end

  private

  include ExternalParentChainer

  def quoted(s)
    "'" + s + "'"
  end

  def output_of(args)
    args[0]
  end

end
