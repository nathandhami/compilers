package com.cmpt470g8.boardio;

import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import java.util.ArrayList;


public class Profile extends ActionBarActivity  {
    public final static String EXTRA_MESSAGE = "com.cmpt470g8.boardio.message";
    ListView listC;
    ListView listA;
    ArrayList<String> listCreated;
    ArrayList<String> listAttending;
    ArrayAdapter<String> cAdapter;
    ArrayAdapter<String> aAdapter;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);
        TextView userName = (TextView) findViewById(R.id.lblUserName);
        TextView email = (TextView) findViewById(R.id.lblEmail);
        userName.setText("johnDoe1991");
        email.setText("john.doe@gmail.com");
        listC = (ListView) findViewById(R.id.listCreatedEvents);
        listA = (ListView) findViewById(R.id.listAttending);
        listCreated = new ArrayList<String>();
        listAttending = new ArrayList<String>();
        cAdapter = new ArrayAdapter<String>(getApplicationContext(), android.R.layout.simple_list_item_1, listCreated);
        aAdapter = new ArrayAdapter<String>(getApplicationContext(), android.R.layout.simple_list_item_1, listAttending);
        listC.setAdapter(cAdapter);
        listA.setAdapter(aAdapter);
        getCreated();
        getAttending();
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_profile, menu);
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

    public void getCreated(){
        listCreated.add("Created 1");
        cAdapter.notifyDataSetChanged();
    }

    public void getAttending() {
        listAttending.add("Attending 1");
        aAdapter.notifyDataSetChanged();
    }
}
