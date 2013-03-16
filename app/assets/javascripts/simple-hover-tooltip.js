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
