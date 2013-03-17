/*
 * This script ensures that the 'simple-foucs-tooltip' can be run on every page.
 * Note that it only shows up for something with class="has-focus-tooltip"
 *
 * This is best used for text_field's and text_area's.
 * The tooltip will always appear to the right, but that can easily be changed.
 * It will only show up when the control gets focus.
 * 
 * To use this, in your text_field, text_field_tag, etc. make sure that:
 * :class => "has-tooltip"
 * :title => "Whatever you want in the tooltip"
 *
 */

$(function() {

  // Right now, anything with class="has-tooltip" will get a tooltip
  $(".has-focus-tooltip").tooltip({
  
    // trigger when it gets focus, i.e. click or tabs it
    trigger: "focus",
    
    // place the tooltip to the right
    placement: "right"

  });
});

/*
 * This is the same thing as simple-focus-tooltip.js, except that it's on hover
 * instead of focus.
 *
 * It's probably horribly redundant code, so IDK if there's a way to make it
 * better style.  I'm hurting on the inside from lack of style, so yeah...
 *
 */

$(function() {

  // Right now, anything with class="has-tooltip" will get a tooltip
  $(".has-hover-tooltip").tooltip({
  
    // trigger when it gets focus, i.e. click or tabs it
    trigger: "hover",
    
    // place the tooltip to the right
    placement: "right"

  });
});
