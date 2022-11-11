/**
 * Created with JetBrains PhpStorm.
 * User: David
 * Date: 26/01/13
 * Time: 16:25
 * To change this template use File | Settings | File Templates.
 */

function setOnlineChecker(id)
{
    setInterval(function() {

        $.get('scripts/get_event_counts.php?id=' + id, function(data) {
            var counts = JSON.parse(data);
            var messageSrc = 'images/img/message_unread.png';
            if (counts.messages == 0)
                messageSrc = 'images/img/message.png';
            $("#messages-count img").attr('src', messageSrc);
            $("#messages-count span").html(counts.messages);

            var eventSrc = 'images/img/event_unread.png';
            if (counts.events == 0)
                eventSrc = 'images/img/event.png';

            $("#events-count img").attr('src', eventSrc);
            $("#events-count span").html(counts.events);
        });

    }, 2 * 60000);


};