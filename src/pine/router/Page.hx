package pine.router;

#if pine.client
  #error "Pages cannot be used in a client context"
#end

@:genericBuild(pine.router.PageBuilder.buildGeneric())
interface Page<@:const Path> {}
