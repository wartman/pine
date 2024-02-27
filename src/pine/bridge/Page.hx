package pine.bridge;

#if pine.client
  #error "Pages cannot be used in a client context"
#end

@:genericBuild(pine.bridge.PageBuilder.buildGeneric())
interface Page<@:const Path> {}
