package com.cmpt470g8.boardio;

import android.content.Intent;
import android.location.Address;
import android.location.Geocoder;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.DatePicker;
import android.widget.EditText;

import java.io.IOException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.Calendar;


public class CreateEvent extends LandingPage {


    public final static String EXTRA_MESSAGE = "com.cmpt470g8.boardio.message";
    public String user;
    public String date;
    public double latitude;
    public double longitude;

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
                            int dayOfMonth) {
                        //Display the changed date to app interface
                        date = monthOfYear+1 + "/" + dayOfMonth + "/" + year;
                    }
                });
        date = dp.getMonth()+1 + "/" + dp.getDayOfMonth() + "/" + dp.getYear();
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

    @Override
    public void onBackPressed() {
        Intent returnIntent = new Intent();
        setResult(RESULT_CANCELED, returnIntent);
        finish();
    }

    public void create(View view) throws UnknownHostException{
        EditText eventName = (EditText) findViewById(R.id.editEventName);
        EditText eventDescription = (EditText) findViewById(R.id.editEventDescription);
        EditText eventLocation = (EditText) findViewById(R.id.editLocation);

        Event myEvent = new Event();
        myEvent.name = eventName.getText().toString();


        myEvent.location = eventLocation.getText().toString();

        Geocoder coder = new Geocoder(this);
        try {
            ArrayList<Address> adresses = (ArrayList<Address>) coder.getFromLocationName(myEvent.location, 50);
            for(Address add : adresses){
                longitude = add.getLongitude();
                latitude = add.getLatitude();

            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        myEvent.date = date;
        myEvent.description = eventDescription.getText().toString();
        myEvent.creator = user;
        myEvent.longitude = Double.toString(longitude);
        myEvent.latitude = Double.toString(latitude);
        SaveAsyncTask tsk = new SaveAsyncTask();
        tsk.execute(myEvent);

        Intent returnIntent = new Intent();
        setResult(RESULT_OK, returnIntent);
        finish();
    }

}
