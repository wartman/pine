package pine.router;

#if pine.client
  #error "Pages cannot be used in a client context"
#end

@:genericBuild(pine.router.PageBuilder.buildGeneric())
class Page<@:const Path> {}
