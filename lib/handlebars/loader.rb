
require 'v8'
require 'pathname'

module Handlebars
  class Loader

    def initialize
      @cxt = V8::Context.new
      @path = Pathname(__FILE__).dirname.join('..','..','js','lib')
      @modules = {}
    end

    def require(modname)
      unless mod = @modules[modname]
        filename = modname =~ /\.js$/ ? modname : "#{modname}.js"
        filepath = @path.join(filename)
        fail LoadError, "no such file: #{filename}" unless filepath.exist?
        load = @cxt.eval("(function(require, module, exports) {#{File.read(filepath)}})", filepath.expand_path)
        object = @cxt['Object']
        mod = object.new
        mod['exports'] = object.new
        @modules[modname] = mod
        load.call(method(:require), mod, mod.exports)
      end
      return mod.exports
    end
  end
end