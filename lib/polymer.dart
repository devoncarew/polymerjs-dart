library polymerjs.polymer;

import 'dart:js';
import 'dart:html';

import 'package:polymerjs/jsutils.dart';
import 'package:polymerjs/polymerdom.dart';
import 'package:polymerjs/polymerbase.dart';

export 'package:polymerjs/polymerdom.dart';

class Polymer extends Object {
  static final JsObject js = context['Polymer'];

  /// Polymer provides a custom API for manipulating DOM such that local DOM and
  /// light DOM trees are properly maintained. These methods and properties have
  /// the same signatures as their standard DOM equivalents, except that properties
  /// and methods that return a list of nodes return an Array, not a NodeList.
  ///
  /// Note: All DOM manipulation must use this API, as opposed to DOM API directly
  /// on nodes.
  ///
  /// Using these node mutation APIs when manipulating children ensures that
  /// shady DOM can distribute content elements dynamically. If you change
  /// attributes or classes that could affect distribution without using the
  /// Polymer.dom API, call distributeContent on the host element to force it
  /// to update its distribution.
  ///
  /// Other resources: https://www.polymer-project.org/1.0/docs/devguide/local-dom.html
  static PolymerDom dom(Node node) => new PolymerDom(node);

  /// Re-evaluates and applies custom CSS properties based on dynamic changes,
  /// such as adding or removing classes in this element's local DOM.
  static updateStyles() => context["Polymer"].callMethod("updateStyles");
}

class WebElement extends Object with JsMixin {
  final HtmlElement element;

  JsObject _js;
  JsObject get js {
    if (_js == null) {
      _js = new JsObject.fromBrowserObject(element);
    }
    return _js;
  }

  WebElement(String tag, [String typeExtension])
      : element = new Element.tag(tag, typeExtension);

  // This is needed to avoid the following issue:
  // https://github.com/dart-lang/sdk/issues/23661
  WebElement.tag(String tag) : this(tag, null);

  // This is needed to avoid the following issue:
  // https://github.com/dart-lang/sdk/issues/23661
  WebElement.extension(String tag, String typeExtension)
      : this(tag, typeExtension);

  WebElement.from(this.element);

  void appendTo(HtmlElement parent) {
    parent.append(element);
  }
}

class PolymerElement extends WebElement with PolymerBase {
  PolymerElement(String tag, [String typeExtension])
      : super.extension(tag, typeExtension);

  PolymerElement.from(HtmlElement element) : super.from(element);

  @override
  dynamic operator [](String propertyName) {
    var property = js[propertyName];
    if (propertyName.contains(".")) {
      property = get(propertyName);
    }
    if (property is JsFunction) {
      return functionFromJs(property, thisArg: js);
    }
    return property;
  }

  @override
  void operator []=(String propertyName, dynamic value) {
    if(propertyName.contains(".")) {
      set(propertyName, value);
    } else {
      js[propertyName] = value;
    }
  }

  dynamic get root => this["root"];

  Map<String, HtmlElement> get $ => this[r'$'];

  /// The user can directly modify a Polymer element's custom style property by
  /// setting key-value pairs in `customStyle` on the element and then calling
  /// `updateStyles.
  JsObject get customStyle => this["customStyle"];

}

/// Finds the first descendant element of this document that matches the
/// specified group of selectors.
HtmlElement $(String selectors) => querySelector(selectors);

PolymerElement $$(String selectors) {
  HtmlElement element = $(selectors);
  if (element == null) {
    return null;
  }
  String name = element.tagName;
  if (!name.contains("-")) {
    return new WebElement.from(element);
  }
  if (constructorFromString.containsKey(name)) {
    return constructorFromString[name](element);
  }
  return new PolymerElement.from(element);
}

Map<String, Function> constructorFromString = {

};