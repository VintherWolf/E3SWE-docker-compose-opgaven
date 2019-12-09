FROM python:3.8
LABEL "Maintainer"="Daniel K.V. Wolf"
EXPOSE 80/tcp
COPY . /flaskapp
WORKDIR /flaskapp
RUN pip install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["flaskapp.py"]