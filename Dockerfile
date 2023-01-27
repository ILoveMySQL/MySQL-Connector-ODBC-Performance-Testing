FROM python:3.10-bullseye

ARG odbcdlurl
RUN { apt-get update && apt install -y unixodbc-dev && wget -qO- $odbcdlurl | tar -xvz -C / --strip-components 1; } && \
    cp /lib/libmyodbc8* /usr/lib/x86_64-linux-gnu/odbc/ && \
    /bin/myodbc-installer -d -a -n "MySQL" -t "DRIVER=/usr/lib/x86_64-linux-gnu/odbc/libmyodbc8w.so;"
RUN pip3 install pyodbc==4.0.32
RUN printf '\n\
import timeit \n\
import pyodbc \n\
mysql_conn = pyodbc.connect("DRIVER=/usr/lib/x86_64-linux-gnu/odbc/libmyodbc8w.so;SERVER=db;DATABASE=sys;UID=root;PWD=example;charset=utf8mb4;") \n\
mysql_cursor = mysql_conn.cursor() \n\
mysql_cursor.execute("SET GLOBAL general_log = 1;") \n\
mysql_cursor.execute("SET global log_output = \x27table\x27;") \n\
mysql_cursor.execute("create temporary table temp(junkvarchar varchar(100));") \n\
start_time = timeit.default_timer() \n\
mysql_cursor.executemany("insert into temp(junkvarchar) values (?)", [("a"*100,) for i in range(100000)]) \n\
print(f"Elapsed Time: {timeit.default_timer() - start_time}") \n\
' >> /test.py
CMD sleep 40 && python3 '/test.py'
