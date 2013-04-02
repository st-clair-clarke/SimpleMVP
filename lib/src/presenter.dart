part of vint;

typedef String Template<T>(T model);

/**
* It binds a model and view.
* Sends commands to the model when the associated view changes.
* Updates the view when the model changes.
*/
class Presenter<T> {
  final html.Element el;
  final Template<T> template;
  final T model;

  final List<StreamSubscription> streamSubscriptions = [];

  /**
   * Improves readability when the model is a list.
   **/
  T get modelList => model;
  
  /**
   * Maps events to event handlers.
   * 
   * Example:
   * {"click a.delete": _onDelete}
   **/
  Map get events => {};

  /**
   * Provides convenient access to rendered elements.
   * 
   * For example:
   * 
   * {firstName : "input[name='firstName']"}
   * 
   * defines a getter on the presenter that returns the input element.
   * It can be used in any method of the presenter:
   * 
   * void _submitForm(){
   *   var firstName = this.firstName.value
   *   ...
   * }
   **/
  Map get ui => {};

  Presenter(this.model, this.el, [this.template]){
    subscribeToModelEvents();
    subscribeToDOMEvents();
  }

  Presenter<T> render(){
    if(template != null){
      el.innerHtml = template(model);
    }
    return this;
  }

  void subscribeToDOMEvents(){
    events.forEach((eventSelector, callback){
      var delegate = new _DelegatedEvent(eventSelector, callback);
      streamSubscriptions.add(delegate.registerOn(el));
    });
  }

  void subscribeToModelEvents(){
  }

  dispose(){
    streamSubscriptions.forEach((_) => _.cancel());
    streamSubscriptions.clear();
  }

  noSuchMethod(InvocationMirror invocation){
    if(invocation.isGetter){
      if(ui.containsKey(invocation.memberName)){
        return el.query(ui[invocation.memberName]);
      }
    }
    throw new NoSuchMethodError(this, invocation.memberName, invocation.positionalArguments, invocation.namedArguments);
  }
}