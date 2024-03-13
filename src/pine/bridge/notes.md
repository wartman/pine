SSR with Client-Side Routing
============================

This is a notional idea for setting up a fully-hydrating site with SSR using an Island as the root. The most important thing is coming up with some kind of collection that can gather all the data for hydration.

Here's a notional setup for the site (assume all the components being used are defined elsewhere):

```haxe
function main() {
  Bridge.build({
    client: {
      outputName: '/assets/app.js'
    },
    // Note: changing the API here a bit to introduce context: 
    render: context -> Html.view(<html>
      <head>
        <SiteTitle />
        <SiteAssets />
      </head>
      <main>
          <Root 
            hydration={new HydrationContext()}
            navigator={Navigator.from(context)} 
          />
        </Scope>
        <SiteScripts />
      </main>
    </html>)
  })
  .generate()
  .next(assets -> assets.process())
  .handle(result -> switch result {
    case Ok(_): trace('Site generated');
    case Error(error): trace(error.message);
  });
}

class Root extends Island {
  @:attribute final navigator:Navigator;
  @:attribute final hydration:HydrationContext;

  function render() {
    return Provider
      .provide(navigator)
      .provide(hydration)
      .children(
        Router.build({
          routes: [
            HomePage.route(),
            OtherPage.route()
          ],
          fallback: err -> ErrorPage.build({
            error: err
          })
        })
      );
  }
}
```

Since the router is defined *inside* the island, the whole component will be re-rendered when we update it. In addition, the `HydrationContext` will be a serializable class that can collect all the data we need for the page in it. `Navigator` is also serializable, which allows us to use it as a hydration attribute as well. Note that Providers don't work into Islands (yet?), so we need to re-provide Navigator so that it'll work inside the client.

`HydrationContext` might look something like this:

```haxe
class HydrationContext extends Model {
  public static function from(context:View) {
    return context.get(HydrationContext)
      .toMaybe()
      .orThrow('No hydration context found');
  }

  @:json(
    to = {
      var output = {};
      for (key => data in value) {
        Reflect.setField(key, data);
      }
      output;
    }
    from = {
      var data:Map<String, {}> = [];
      for (field in Reflect.fields(value)) {
        data.set(field, Reflect.field(value, field));
      }
      data;
    }
  )
  @:signal final entries:Map<String, {}> = [];
  @:signal final uid:Int = 0;

  public function requestId() {
    uid.update(id -> id + 1);
    return uid.peek();
  }

  public function setEntry(id:Int, data:{}) {
    entries.update(entries -> {
      entries.set(id + '', data);
      entries;
    });
  }

  public function getEntry(id:Int):Maybe<{}> {
    var data = entries.peek().get(id);
    return data == null ? None : Some(data);
  }
}
```

...and would have to be used internally something like this:

```haxe
function getData(context:View, path:String):Task<{}> {
  var hydration = HydrationContext.from(context);
  var id = hydration.requestId();
  SomeApi.from(context).get(path).next(data -> {
    hydration.setEntry(id, data);
    data;
  });
}
```

It will have to be more complicated than that, but basically we'll have hacked our Islands API to just take care of all hydration for us by doing this.
