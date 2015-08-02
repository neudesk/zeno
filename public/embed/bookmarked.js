var chrome, safari, mobile;
chrome = navigator.userAgent.toLowerCase().indexOf("chrome") > -1;
safari = navigator.userAgent.toLowerCase().indexOf("safari") > -1;
mobile = (/iphone|ipad|ipod|android|blackberry|mini|windows\sce|palm/i.test(navigator.userAgent.toLowerCase()));

window.onload = function () {
  $("a.bookmark").click(function(e) {
    var bookmarkTitle, bookmarkUrl;
    e.preventDefault();
    bookmarkUrl = this.href;
    bookmarkTitle = this.title;
    if (chrome) {
      alert("Press Ctrl + D to bookmark this site.");
    } else if (window.sidebar) {
      window.sidebar.addPanel(bookmarkTitle, bookmarkUrl, "");
    } else if (window.external || document.all) {
      window.external.AddFavorite(bookmarkUrl, bookmarkTitle);
    } else if (window.opera) {
      $("a.bookmark").attr("href", bookmarkUrl);
      $("a.bookmark").attr("title", bookmarkTitle);
      $("a.bookmark").attr("rel", "sidebar");
    } else {
      alert("Your browser does not support this bookmark action");
      false;
    }
  });


  if (!mobile) {
    $("a.phonebook").click(function(e) { 
      e.preventDefault();
      alert("Please view this page on your mobile device to automatically add the radio number to your phone book.");
    });
  }

  $("a.bookmark").each(function() {
    if (chrome || safari) {
      // return $(this).hide();
    }
  });

  $("a.download_quickplay").each(function() {
    href = $(this).attr("href") + "&url=" + window.location.href
    $(this).attr("href", href)
  });
}

