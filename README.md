# AL2Tat Description

Alerts to Tat.

This microservice can be used :
* to send alerts to Tat (https://github.com/ovh/tat).
* to send monitoring events to Tat.


## Alerts
An alert is an event with a 'AL' status. An alert can be replayed, al2tat attach
this on a root message. If there is a new occurrence with same summary with
'UP' status, alert will be closed.
Best Tat view for theses: StandardView (https://github.com/ovh/tatwebui-plugin-standardview)

* Compute Replay: if alarm already exists, the replay will be a reply of root alarm
* Pre-select Label :
 * a new alarm "AL" will receive label "open" with red color on tat
 * a new alarm "UP" will receive label "done" with green color on tat
 * A new alarm "AL" will close previous "AL" in same thread


## Monitoring Events
An event monitoring is attached to one item (host, soft, person... whatever), all events are held three days, and only 30 events are retained after 3d. Best Tat view for theses: Monitoring View (https://github.com/ovh/tatwebui-plugin-monitoringview)


# Usage of AL2Tat
## Alert
### Store new alert

If `Tat_topic == ""`, default value is `/Internal/Alerts`

```
curl -XPOST \
    -H "Content-Type: application/json" \
    -H "Tat_username: yourTatUser" \
    -H "Tat_password: yourTatPassword" \
    -H "Tat_topic: /Internal/Alerts" \
    -d '{
    "status": "AL",
    "nbAlert": 1,
    "service": "YourService",
    "summary": "your alert description here"
}' http://<hostname>:<port>/alert
```

`nbAlert` can be used to represent the number of elements impacted by your alert.
It is not used to compute alert's repetitions.

### Store new alert with a label

If `Tat_topic == ""`, default value is `/Internal/Alerts`

```
curl -XPOST \
    -H "Content-Type: application/json" \
    -H "Tat_username: tatusername" \
    -H "Tat_password: tatpassword" \
    -H "Tat_topic: /Internal/Alerts" \
    -d '{
    "status": "AL",
    "nbAlert": 3,
    "service": "YourService",
    "labels": [{"text": "critical:high", "color":"#d04437"}],
    "summary": " your alert description here"
}' http://<hostname>:<port>/alert
```

### Sync vs Async

POST on `http://<hostname>:<port>/alert`: send asynchronous to tat engine.

POST on `http://<hostname>:<port>/alert/sync`: send synchronous to tat engine, and return message

### Purge alerts

You have to call endpoint: `/purge/:skip/:limit` to purge Tat_topic, for keeping
30 replies on each alerts.

Purge example the last 100 alerts on tat :

```
curl -XPUT \
    -H "Content-Type: application/json" \
    -H "Tat_username: tatusername" \
    -H "Tat_password: tatpassword" \
    -H "Tat_topic: /Internal/Alerts"
}' http://<hostname>:<port>/purge/0/100

```

## Monitoring
### Store a new event
```  
curl -XPOST \
    -H "Content-Type: application/json" \
    -H "Tat_username: yourTatUser" \
    -H "Tat_password: yourTatPassword" \
    -H "Tat_topic: /Internal/Monitoring" \
    -d '{
    "status": "AL",
    "item": "yourApplication",
    "service": "SERVICE",
    "summary": "your description",
    "labels": [{"text": "critical:high", "color":"#d04437"}]
}' http://<hostname>:<port>/monitoring
```

with :

```
status: AL or UP
service: your service
summary: description of event
item: your application name, or host...
labels: facultative, add labels to message root, the first message sent for an item.
```

### Sync vs Async

POST on http://<hostname>:<port>/monitoring: send asynchronous to tat engine.

POST on http://<hostname>:<port>/monitoring/sync: send synchronous to tat engine, and return message


## System
### Version

```
curl -XGET http://<tatHostname>:<tatPort>/version
```

# RUN

## Al2Tat Flags Options

```
Flags:
  -h, --help[=false]: help for al2tat
      --listen-port="8082": Tat Engine Listen Port
      --log-level="": Log Level: debug, info or warn
      --production[=false]: Production mode
      --url-tat-engine="http://localhost:8080": URL Tat Engine
```

## Run with Docker
```
docker build -t al2tat .
docker run -it --rm --name al2tat-instance1 <hostname>>:<port> al2tat
```

## Run with Sailabove

### AL2Tat Service
```
docker build -t al2tat .
docker tag -f al2tat sailabove.io/<yourSailaboveUsername>/al2tat
docker push sailabove.io/<yourSailaboveUsername>/al2tat

sail services add <yourSailaboveUsername>/al2tat \
  --network predictor \
  --network private \
  -e TAT_PRODUCTION=true -p 80:80 al2tat
```

## Dev RUN

```
go get && go build && ./al2tat --help
```

### Environment

* AL2TAT_LISTEN_PORT

Example :
```
export AL2TAT_LISTEN_PORT=8181 && ./al2tat
```
is same than
```
./al2tat --listen-port="8181"
```


# Examples of POST an alert

## Perl version

```
package AL2TAT;

use Exporter qw(import);

our @EXPORT_OK = qw(run getMessage);

use strict;
use warnings;
use LWP::UserAgent;

sub run
{
  my <hostname>:<port>/alert";
  my $TAT_TOPIC_KEY = "/Private/yourTopic";
  my $TAT_USER_KEY = "yourUsernameOnTat";
  my $TAT_PASSWORD_KEY = "yourTatVeryLongPasswordHere";

  my $message = getMessage();
  sendMessage($TAT_URL_KEY, $TAT_TOPIC_KEY, $TAT_USER_KEY, $TAT_PASSWORD_KEY, $message);
}

sub sendMessage
{
    my $url = $_[0];
    my $topic = $_[1];
    my $user = $_[2];
    my $password = $_[3];
    my $message = $_[4];

    my $req = HTTP::Request->new(POST => $url);
    $req->header('Content-Type' => 'application/json');
    $req->header('Tat_username' => $user);
    $req->header('Tat_password' => $password);
    $req->header('Tat_topic' => $topic);

    my $post_data = '{"status": "AL", "nbAlert": 1, "service": "TEST", "summary": "'.$message.'"}';
    $req->content($post_data);

    my $ua = LWP::UserAgent->new;
    my $resp = $ua->request($req);

    print "Response Status: ", $resp->code, "\n";
    if ($resp->is_success) {
        my $message = $resp->decoded_content;
        print "Received reply: $message\n";
    } else {
        print "HTTP POST error message: ", $resp->message, "\n";
    }
}

sub getMessage
{
    return "Message from perl ";
}

run()

```

# Hacking

Tat is written in Go 1.5, using the experimental vendoring
mechanism introduced in this version. Make sure you are using at least
version 1.5.

```bash
mkdir -p $GOPATH/src/github.com/ovh
cd $GOPATH/src/github.com/ovh
git clone git@github.com:ovh/al2tat.git
cd $GOPATH/src/github.com/ovh/al2tat
export GO15VENDOREXPERIMENT=1
go build
```

You've developed a new cool feature? Fixed an annoying bug? We'd be happy
to hear from you! Make sure to read [CONTRIBUTING.md](./CONTRIBUTING.md) before.
