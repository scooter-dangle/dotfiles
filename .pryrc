Pry.config.theme = 'twilight'

RequiredPaths = {}

def reversibly_require(path)
  return false if RequiredPaths[path]
  original_constants = Object.constants
  require path
  return true
ensure
  new_constants = Object.constants - original_constants
  RequiredPaths[path] = new_constants
end

def unrequire(path)
  return false unless RequiredPaths[path]
  RequiredPaths.delete(path).each do |const|
    Object.send(:remove_const, const)
  end
  return true
end

def re_require(path)
  unrequire(path)
  reversibly_require(path)
end
