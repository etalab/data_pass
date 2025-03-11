import { Controller } from '@hotwired/stimulus'

// Usage:
// - specify the selector string for all elements in the "targets" value (ie ".some_class,#an_id")
// - each element that triggers should specify the selector of the elements to display (ie "#an_id")
// - the diff between the two are the elements that will be hidden on trigger (ie ".some_class")
//
// The controller can be nested as it works on its children elements (be careful with the selectors though)
//
// Example:
// <div data-controller="show-and-hide" data-show-and-hide-targets-value="#option1, #option2">
//   <a data-action="click->show-and-hide#trigger" data-show-and-hide-target-param="#option1">Option 1</a>
//   <a data-action="click->show-and-hide#trigger" data-show-and-hide-target-param="#option2">Option 2</a>
//
//   <div id="option1" class="fr-hidden">Option 1 content</div>
//   <div id="option2" class="fr-hidden" data-controller="show-and-hide" data-show-and-hide-targets-value="#sub_option1, #sub_option2">
//     Option 2 content
//
//     <a data-action="click->show-and-hide#trigger" data-show-and-hide-target-param="#sub_option1">Option 1</a>
//     <a data-action="click->show-and-hide#trigger" data-show-and-hide-target-param="#sub_option2">Option 2</a>
//
//     <div id="sub_option1" class="fr-hidden">SUB Option 1 content</div>
//     <div id="sub_option2" class="fr-hidden">SUB Option 2 content</div>
//   </div>
// </div>

export default class extends Controller {
  static values = {
    displayClass: { type: String, default: 'fr-hidden' },
    targets: String
  }

  trigger (event) {
    const selector = event.params.target

    this._elementsToHide(selector).forEach(target => target.classList.add(this.displayClassValue))
    this._elementsToDisplay(selector).forEach(target => target.classList.remove(this.displayClassValue))
  }

  _elementsToDisplay (selector) {
    return this.element.querySelectorAll(selector)
  }

  _elementsToHide (exceptSelector) {
    const filteredSelector = this.targetsValue.split(',').filter(target => target !== exceptSelector).join(',')
    return filteredSelector.trim() ? this.element.querySelectorAll(filteredSelector) : []
  }
}
