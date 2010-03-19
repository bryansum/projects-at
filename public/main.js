function autocomplete() {
  // timer for autocompletion
  var TIMEOUT = 800, self = this, t_id, suggest=[], s_i=0, ele=$('#tags'), bucket=$('#tag-bucket');
  
  function compact(ar) { var r = []; for(var i=0; i<ar.length;i++) {if (ar[i]) r.push(ar[i]);} return r; }
  function find(ele, ar) {for(var i=0; i<ar.length;i++){ if (ar[i] == ele) return i; } return -1; }

  function el_tags() { return ele.val().split(/\s+/); }
  
  function add_tag(str) {
    if (find(str, el_tags()) == -1) {
      ele.val(ele.val()+" "+str);
    } 
  } 
  
  function fill_bucket(str) {
    bucket.html(str||""+" ");
    for (var i = suggest.length - 1; i >= 0; i--){
      bucket.append($('<a class="tag">'+suggest[i]['tag']+'</a> ').click(function(){
        add_tag($(this).text());
      }));
    };
  }
  
  function replace_words() {
    var tags = el_tags(), o = tags.slice(0,-1), str = o.length ? o.join(" ")+" " : "", word = suggest[s_i]['tag'];
    if (find(word, tags) == -1) ele.val(str+word);
  }
  
  ele.keyup(function(e){
    if (t_id) clearTimeout(t_id);
    if (e.which == 9 || e.which == 8) return;
    var tags = el_tags(), last = tags.slice(-1)[0];
    if (last) {
      t_id = setTimeout(function(){
        $.getJSON("/tags/complete/"+last,function(ts){
          suggest = ts; s_i = 0;
          if (suggest.length) { 
            replace_words();
            fill_bucket(); 
          } else {
            bucket.html("");
          }
        });        
      }, TIMEOUT);
    }    
  });
  
  ele.keydown(function(e){
    if (t_id) clearTimeout(t_id);
    if (e.which == 9 && suggest.length) { //TAB
      e.preventDefault();
      s_i++; if (s_i >= suggest.length) { s_i = 0; }; replace_words(); return;
    }
  });  
  
  $.getJSON("/tags/popular",function(ts){
    suggest = ts; s_i = 0;
    if (suggest.length) { 
      fill_bucket("popular tags:"); 
    }
  });
}

$(document).ready(function(){
  autocomplete();
});

