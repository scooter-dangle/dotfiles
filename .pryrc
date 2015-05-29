Pry.config.editor = 'vim'
Pry.config.theme = 'twilight'

def dump_session(filename = 'marshal.dump')
  IO.write(new_dump_filename(filename), Marshal.dump(instance_variables_hash))
end

def load_session(filename = 'marshal.dump')
  Marshal.load(IO.read(dump_filename(filename))).each do |var, value|
    instance_variable_set(var, value)
  end
  if instance_variable_defined?('@_dump_evals')
    @_dump_evals.each do |var, value|
      instance_variable_set(var, eval(value))
    end
  else
    @_dump_evals = {}
  end
  instance_variables
end

def instance_variables_hash
  verboten_vars = instance_variable_defined?('@_dump_evals') ?
    @_dump_evals.keys :
    []
  instance_variables.-(verboten_vars).map do |var|
    [var, instance_variable_get(var)]
  end.to_h
end

def new_dump_filename(base_filename = 'marshal.dump')
  return base_filename unless File.exists?(base_filename)

  moar_files = Dir["*_#{base_filename}"]
  return "0_#{base_filename}" if moar_files.empty?

  dump_filename_sort(moar_files, base_filename).last.split(?_).tap { |prefix, *_| prefix.replace(prefix.succ) }.join(?_)
end

def dump_filename(base_filename = 'marshal.dump')
  dump_filename_sort(Dir["{,*_}#{base_filename}"], base_filename).last
end

def dump_filename_sort(filenames, base_filename = 'marshal.dump')
  filenames.sort_by do |filename|
    match = filename[/\A\d+(?=_#{base_filename}\z)/]
      match ?
      match.to_i :
      -1
  end
end
