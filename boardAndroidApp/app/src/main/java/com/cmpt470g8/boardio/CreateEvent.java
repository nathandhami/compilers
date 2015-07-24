package com.cmpt470g8.boardio;

import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.DatePicker;
import android.widget.EditText;
import java.net.UnknownHostException;
import java.util.Calendar;


public class CreateEvent extends LandingPage {


    public final static String EXTRA_MESSAGE = "com.cmpt470g8.boardio.message";
    public String user;
    public String date;

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
        myEvent.__v = 0;
        SaveAsyncTask tsk = new SaveAsyncTask();
        tsk.execute(myEvent);

        Intent returnIntent = new Intent();
        setResult(RESULT_CANCELED, returnIntent);
        finish();
    }
}
