#! /bin/bash -eux
if [[ "${DEBUG:-False}" == "True" ]]; then
    pip install -r requirements-dev.txt
fi

cmd="${1:-serve}"

case "$cmd" in
    feed-update-daemon)
	./mfdr -d
	;;
    beat)
        if [ -f /tmp/celerybeat.pid ]; then
            rm /tmp/celerybeat.pid
        fi
        python manage.py migrate
        celery -A mygpo beat --pidfile /tmp/celerybeat.pid -S django
        ;;
    worker)
        python manage.py migrate
        celery -A mygpo worker --concurrency=3 -l info -Ofair
        ;;
    serve)
        python manage.py migrate
        python manage.py collectstatic --no-input
        python manage.py runserver 0.0.0.0:8000
        ;;
    *)
        "$@"
        ;;
esac
