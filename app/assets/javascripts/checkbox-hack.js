$(function()
{
  $('.checkbox-hack + .checkbox-controlled').hide();
  $('.checkbox-hack').siblings('label').click(function()
  {
    $(this).find('.icon-caret-right').toggleClass('rotated-45deg');
    $(this).next('.checkbox-controlled').slideToggle();
  });
  $('.checkbox-hack').remove();
});