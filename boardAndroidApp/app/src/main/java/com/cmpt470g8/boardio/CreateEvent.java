package com.cmpt470g8.boardio;

import android.content.Intent;
import android.os.AsyncTask;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import java.util.Calendar;
import android.widget.DatePicker;
import java.net.UnknownHostException;

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;
import org.w3c.dom.Text;


public class CreateEvent extends LandingPage {


    public final static String EXTRA_MESSAGE = "com.cmpt470g8.boardio.message";
    public String user;
    public String date;
    public class Event {
        public String name;
        public String date;
        public String location;
        public String description;
    }

    public class QueryBuilder {
        public String getDataBaseName(){
            return "board";
        }
        public String getAPIKey(){
            return "S0DeU0yPg3419W2mT-L7z5mEtVzmhcKO";
        }
        public String getBaseURL(){
            return "https://api.mongolab.com/api/1/databases/"+getDataBaseName()+"/collections/";
        }
        public String docApiKeyUrl()
        {
            return "?apiKey="+getAPIKey();
        }
        public String documentRequest()
        {
            return "events";
        }
        public String buildEventsSaveURL()
        {
            return getBaseURL()+documentRequest()+docApiKeyUrl();
        }
        public String createEvent(Event event)
        {
            return String
                    .format("{\"event\" : {\"date\": \"%s\", "
                                    + "\"location\": \"%s\", \"description\": \"%s\", "
                                    + "\"name\": \"%s\"}, \"safe\" : true}",
                            event.date, event.location, event.description, event.name);
        }
    }

    public class SaveAsyncTask extends AsyncTask<Event, Void, Boolean> {

        @Override
        protected Boolean doInBackground(Event... arg0) {
            try {
                Event event = arg0[0];

                QueryBuilder qb = new QueryBuilder();

                HttpClient httpClient = new DefaultHttpClient();
                HttpPost request = new HttpPost(qb.buildEventsSaveURL());

                StringEntity params = new StringEntity(qb.createEvent(event));
                request.addHeader("content-type", "application/json");
                request.setEntity(params);
                HttpResponse response = httpClient.execute(request);

                if (response.getStatusLine().getStatusCode() < 205) {
                    return true;
                } else {
                    return false;
                }
            } catch (Exception e) {
                //e.getCause();
                String val = e.getMessage();
                String val2 = val;
                return false;
            }
        }
    }
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_create_event);
        Calendar c= Calendar.getInstance();
        int year = c.get(c.YEAR);
        int month = c.get(c.MONTH);
        int dayOfMonth = c.get(c.DAY_OF_MONTH);
        Intent intent = getIntent();
        user = intent.getStringExtra(EXTRA_MESSAGE);
        DatePicker dp = (DatePicker) findViewById(R.id.datePicker);
        dp.init(
                year,
                month,
                dayOfMonth,
                new DatePicker.OnDateChangedListener() {

                    @Override
                    public void onDateChanged(
                            DatePicker view,
                            int year,
                            int monthOfYear,
                            int dayOfMonth)
                    {
                        //Display the changed date to app interface
                        date = monthOfYear + "/" + dayOfMonth + "/" + year;
                    }
                });
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_create_event, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public void create(View view) throws UnknownHostException{
        EditText eventName = (EditText) findViewById(R.id.editEventName);
        EditText eventDescription = (EditText) findViewById(R.id.editEventDescription);
        EditText eventLocation = (EditText) findViewById(R.id.editLocation);

        Event myEvent = new Event();
        myEvent.name = eventName.getText().toString();

        myEvent.location = eventLocation.getText().toString();
        myEvent.date = date;
        myEvent.description = eventDescription.getText().toString();
        SaveAsyncTask tsk = new SaveAsyncTask();
        tsk.execute(myEvent);

        Intent returnIntent = new Intent();
        setResult(RESULT_CANCELED, returnIntent);
        finish();
    }
}
