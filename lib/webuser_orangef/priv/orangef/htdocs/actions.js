function nav_back() {
    window.history.back();
}

function redir_search() {
    window.location="http://"+window.location.host+
    	"/secure/erl/webuser_search_orangef:show";
}

function close_window() {
    top.window.opener = top;
    top.window.open('','_self','');
    top.window.close();
}


function load() {
    fill_id();
}

function load_with_args(num,id,begin_time,end_time) {
    document.getElementById(num+"_type").click();
    document.getElementById("text_id").value = id;
    t = document.getElementById("select_time_beg");
    i = find_elem(begin_time,t.options);
    if (i < 0) i = 0;
    t.selectedIndex = i;
    t = document.getElementById("select_time_end");
    i = find_elem(end_time,t.options);
    if (i < 0) i = 0;
    t.selectedIndex = i;
}

function find_elem(elem,arr) {
    for (i = 0; i < arr.length; i++) {
        if (elem == arr[i].value) {
            return i;
        }
    }
    return -1;
}

function fill_id() {
    t = document.getElementById("text_id");
    if (document.getElementById("msisdn_type").checked) {
        t.value="+336";
    } else if (document.getElementById("imsi_type").checked) {
        t.value="20801";
    }
}

