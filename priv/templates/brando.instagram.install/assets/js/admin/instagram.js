import $ from 'jquery';
import brando from 'brando';

var imagePool = [];

class Instagram {
  static setup() {
    this.checkButtonEnable();
    this.changeStatusListener();
    this.imageSelectionListener();
  }

  static imageSelectionListener() {
    var that = this;
    $('.image-selection-pool img')
      .click(function() {
        if ($(this)
          .hasClass('selected')) {
          // remove from selected pool
          var pos;
          for (var i = 0; i < imagePool.length; i++) {
            if (imagePool[i] == $(this)
              .attr('data-id')) {
              pos = i;
              break;
            }
          }
          imagePool.splice(pos, 1);
        } else {
          // add to selected pool
          if (!imagePool) {
            imagePool = new Array();
          }
          imagePool.push($(this)
            .attr('data-id'));
        }
        $(this)
          .toggleClass('selected');
        that.checkButtonEnable();
      });
  }

  static checkButtonEnable() {
    let $btn = $(
      '.delete-selected-images, .approve-selected-images, .reject-selected-images');
    if (imagePool.length > 0) {
      $btn.prop('disabled', false);
    } else {
      $btn.prop('disabled', true);
    }
  }

  static changeStatusListener() {
    var that = this;
    $('.delete-selected-images')
      .click(function(e) {
        e.preventDefault();
        that.changeStatus(0, imagePool);
      });
    $('.reject-selected-images')
      .click(function(e) {
        e.preventDefault();
        that.changeStatus(1, imagePool);
      });
    $('.approve-selected-images')
      .click(function(e) {
        e.preventDefault();
        that.changeStatus(2, imagePool);
      });
  }

  static changeStatus(status, images) {
    var that = this;
    $.ajax({
      headers: {
        Accept: 'application/json; charset=utf-8'
      },
      type: 'POST',
      url: brando.Utils.addToPathName('change-status'),
      data: {
        ids: images,
        status: status
      },
      success: that.changeStatusSuccess
    });
  }

  static changeStatusSuccess(data) {
    let newStatus = '';
    if (data.status == 200) {
      switch (data.new_status) {
      case '0':
        newStatus = 'deleted';
        break;
      case '1':
        newStatus = 'rejected';
        break;
      case '2':
        newStatus = 'approved';
        break;
      }
      for (let i = 0; i < data.ids.length; i += 1) {
        $('.image-selection-pool img[data-id=' + data.ids[i] + ']')
          .fadeOut(500, function() {
            $(this)
              .detach()
              .appendTo('.' + newStatus)
              .fadeIn()
              .attr('data-status', newStatus);
          });
      }
      imagePool = [];
      $('.image-selection-pool img').removeClass('selected');
    }
  }
}

export default Instagram;
