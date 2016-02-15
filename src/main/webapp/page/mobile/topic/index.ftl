<#include "/page/mobile/common/_layout.ftl"/>
<@html title="${topic.title!} - ${siteTitle!}" description="${topic.title!}">
<link rel="stylesheet" href="${baseUrl!}/static/css/jquery.atwho.min.css">
<script src="${baseUrl!}/static/js/lodash.min.js"></script>
<script src="${baseUrl!}/static/js/jquery.atwho.min.js"></script>

<div class="panel panel-default">
    <div class="panel-body <#if topic.good == 1>np-label-digest</#if>">
        <div style="font-size: 16px;padding-bottom: 5px; font-weight: 600;">${topic.title!}</div>
        <div style="font-size: 10px;color: #838383;">
            <span>
                ${topic.formatDate(topic.in_time)!}&nbsp;
            </span>
            <span>作者 <a href="${baseUrl!}/user/${topic.author_id!}">${topic.nickname}</a>&nbsp;</span>
            <span>${topic.view!} 次浏览&nbsp;</span>
            <span>
                来自<a href="${baseUrl!}/?tab=${topic.tab}">${topic.sectionName!}</a>
            </span>
            <#if session.user?? && topic.author_id == session.user.id>
                <span style="display: inline-block; float: right;padding-top:2px;">
                    <a href="${baseUrl!}/topic/edit/${topic.id!}"><span class="glyphicon glyphicon-pencil"></span></a>&nbsp;&nbsp;
                    <a href="javascript:if(confirm('确定要删除此话题吗？'))location='${baseUrl!}/topic/delete/${topic.id!}'"><span
                            class="glyphicon glyphicon-trash" style="cursor:pointer;"></span></a>
                </span>
            </#if>
        </div>
    </div>
    <div class="panel-body sep">
        <div id="topic_content" class="hidden word-wrap">
            ${topic.content!}
        </div>
        <div>
            <#list labels as label>
                <a href="${baseUrl!}/?tab=${topic.tab!}&l=${label.id!}">
                    <span class="label label-success label-item">${label.name!}</span>
                </a>
            </#list>
        </div>
    </div>
    <#if session.user??>
        <div class="panel-body sep">
            <#if collect??>
                <input type="button" id="collect" onclick="collect(2, '${topic.id!}')"
                       class="btn btn-raised btn-xs btn-default" value="取消收藏"/>
            <#else>
                <input type="button" id="collect" onclick="collect(1, '${topic.id!}')"
                       class="btn btn-raised btn-xs btn-default" value="加入收藏"/>
            </#if>
        </div>
    </#if>
</div>
<div class="panel panel-default">
    <div class="panel-body sep" style="padding-top:3px;">${topic.reply_count!"0"} 回复</div>
    <#list replies as reply>
        <div class="panel-body" style="border-top: solid #F0F0F0 1px;">
            <div id="${reply.id!}" style="min-height: 70px;" <#if reply.isdelete == 1>class="np-label-del"</#if>>
                <a href="${baseUrl!}/user/${reply.author_id}">
                    <img src="${reply.avatar!}" width="24" title="${reply.nickname!}">
                </a>
                <span style="vertical-align: super;">
                    <a href="${baseUrl!}/user/${reply.author_id!}" data_class="atwho" data_id="${reply.author_id!}">${reply.nickname!}</a>
                    ${reply.formatDate(reply.in_time)!}
                </span>
                <#if session.user??>
                    <div style="float: right;">
                        <span>
                            <#if topic.tab == 'ask'>
                                <#if bestReply == 1>
                                    <#if reply.best == 1>
                                        已采纳
                                    </#if>
                                <#else>
                                    <#if session.user?? && topic.author_id == session.user.id>
                                        <span id="bestReply_${reply.id!}">
                                            <a href="javascritp:;" onclick="bestReply('${topic.id!}', '${reply.id!}')">
                                                <span class="glyphicon glyphicon-ok" title="采纳此回复"></span>
                                            </a>
                                        </span>
                                    </#if>
                                </#if>
                            </#if>
                        </span>
                    </div>
                </#if>
                <div>
                    <div id="reply_content_${reply_index}" class="hidden reply_content word-wrap">
                        ${reply.content!}
                    </div>
                </div>
            </div>
        </div>
    </#list>
</div>
<#if session.user??>
    <div class="panel panel-default" id="reply_input">
        <div class="panel-body sep" style="padding-top:3px;">添加回复</div>
        <div class="panel-body sep">
            <form action="${baseUrl!}/reply/${topic.id!}" method="post" id="reply_form">
                <div id="reply_content"><textarea id="content" name="content" class="form-control" style="height: 70px;"></textarea></div>
                <input type="submit" class="btn btn-raised btn-default btn-xs" value="回复" style="margin: 3px 0 0 0;">
            </form>
        </div>
    </div>
</#if>
<script>
    $(function () {
        $("#reply_form").submit(function () {
            if ($.trim($("#content").val()) == "") {
                alert("内容不能为空");
                return false;
            }
            return true;
        });
    });

    var _type = 0;
    function collect(type, tid) {
        var url = "${baseUrl!}/collect/" + tid;
        if (_type == 0) _type = type;
        if (_type == 2) url = "${baseUrl!}/collect/delete/" + tid;
        $.ajax({
            url: url,
            async: false,
            cache: false,
            type: 'post',
            dataType: "json",
            data: {},
            success: function (data) {
                if (data.code == '200') {
                    if (_type == 1) {
                        _type = 2;
                        $("#collect").removeClass("btn-default");
                        $("#collect").addClass("btn-default");
                        $("#collect").val("取消收藏");
                    } else {
                        _type = 1;
                        $("#collect").removeClass("btn-default");
                        $("#collect").addClass("btn-default");
                        $("#collect").val("加入收藏");
                    }
                } else {
                    alert(data.description);
                }
            }
        });
    }

    function bestReply(tid, rid) {
        if(confirm("确定采纳此回答吗?")) {
            $.ajax({
                url: '${baseUrl!}/reply/best',
                async: false,
                cache: false,
                type: 'post',
                dataType: "json",
                data: {
                    rid: rid,
                    tid: tid
                },
                success: function (data) {
                    if (data.code == '200') {
                        $("span[id^='bestReply_']").each(function (i, item) {
                            $(item).html("");
                        });
                        $("#bestReply_" + rid).html("已采纳")
                    } else {
                        alert(data.description);
                    }
                }
            });
        }
    }

    var nicknames = [];
    nicknames[0] = {author_id:'${topic.author_id!}', name: '${topic.nickname!}'};
    $("a[data_class='atwho']").each(function (i, item) {
        nicknames[i + 1] = {author_id:$(item).attr('data_id') ,name:$(item).text()};
    });

    $('#content').atwho({
        at: '@',
        data: _.uniq(nicknames, 'author_id')
    });
</script>
</@html>