# Task_4_Spark_Demo_Course
## 1. To create environment in docker:
    Download docker-compose.yml
    Run docker containers: docker-compose up
    **Note: Don't forget chenge volumes for correct directories in docker-compose.yml
## 2. To execute Jupiter notebook and use pyspark: 
    docker exec -it task_4_spark_demo_course-jupyter-1 bash
    pip install pyspark
    pip install findspark
    jupyter notebook
## 3. To execute Spark:
    docker exec -it task_4_spark_demo_course-spark-1 bash
    pip install py4j
    # Deploy master
    spark-class org.apache.spark.deploy.master.Master
    # Run Workers. Don't forget change master adress, take URL from Spark Master
    spark-class org.apache.spark.deploy.worker.Worker spark://0a7a8fe5c3d8:7077 --cores 2 --memory 3g
    spark-class org.apache.spark.deploy.worker.Worker spark://0a7a8fe5c3d8:7077 --cores 3 --memory 4g
## 4. Change in spark_basics.py: 
   - change of path for loading and saving data
   - explicit indication of the master's address
   - explicit indicatin of directory for saving logs





