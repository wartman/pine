package pine;

import haxe.ds.Option;
import pine.adapter.Adapter;
import pine.core.DisposableHost;
import pine.element.*;

/**
  Every AutoComponent's `render` method will get access to
  its current `Context` -- in actuality the Element
  the Component is configuring. Using `Context` ensures
  the API is locked down to a few methods instead of exposing
  the entire Element.
**/
interface Context extends DisposableHost {
  /**
    Get the actual target element is rendering to. This
    can change greatly depending on the current Adapter,
    so care should be taken while using this method. You
    should avoid using this method unless you absolutely 
    have to.

    When targeting the client and using `pine.html`,
    this will return a `js.html.Node`. On the server, this
    will return a `pine.object.Object`. Other adapters will
    have their own targets.
  **/
  public function getObject():Dynamic;

  /**
    Get the current component attached to this 
    context.
  **/
  public function getComponent<T:Component>():T;
  
  /**
    Get the current adapter.
  **/
  public function getAdapter():Option<Adapter>;

  /**
    Returns a query builder that lets you search *up* 
    the component tree.
  **/
  public function queryAncestors():AncestorQuery;
  
  /**
    Returns a query builder that lets you search *down*
    the component tree.
  **/
  public function queryChildren():ChildrenQuery;
}
