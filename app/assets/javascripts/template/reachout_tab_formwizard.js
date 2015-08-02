$(document).ready(function(){
    $('#wizard').smartWizard({
        selected: 0,
        keyNavigation: false,
        onShowStep: onShowStep()
    });
    animateBar();
});
function animateBar(val) {
    if ((typeof val == 'undefined') || val == "") {
        val = 1;
    };
    numberOfSteps = $('.swMain > ul > li').length;
    var valueNow = Math.floor(100 / numberOfSteps * val);
    $('.step-bar').css('width', valueNow + '%');
};

function onShowStep(obj, context) {
    var wizardContent = $('#wizard');
    var wizardForm = $('#form');
    $(".next-step").unbind("click").click(function (e) {
        e.preventDefault();
        wizardContent.smartWizard("goForward");
        updateBar();
    });
    $(".back-step").unbind("click").click(function (e) {
        e.preventDefault();
        wizardContent.smartWizard("goBackward");
        updateBar();
    });
    $(".finish-step").unbind("click").click(function (e) {
        e.preventDefault();
        onFinish(obj, context);
        updateBar();
    });
};

function updateBar(){
    val = parseInt($('a.selected').attr('rel'));
    animateBar(val);
}
