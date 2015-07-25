package com.cmpt470g8.boardio;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import java.util.ArrayList;


public class Details extends AppCompatActivity {

    public final static String EXTRA_MESSAGE = "com.cmpt470g8.boardio.message";
    private ArrayAdapter<String> mAdapter;
    ListView list;
    ArrayList<String> listItems;
    ArrayAdapter<String> adapter;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_details);
        Intent intent = getIntent();
        Bundle bundle = intent.getBundleExtra(EXTRA_MESSAGE);
        TextView activityName = (TextView) findViewById(R.id.activityName);

        activityName.setText(bundle.getString("name"));
        list = (ListView)findViewById(R.id.listDetails);
        listItems = new ArrayList<String>();
        adapter = new ArrayAdapter<String>(getApplicationContext(), android.R.layout.simple_list_item_1, listItems);
        list.setAdapter(adapter);
        listItems.add("What: " + bundle.getString("description"));
        listItems.add("When: " + bundle.getString("date"));
        listItems.add("Where: " + bundle.getString("location"));

        adapter.notifyDataSetChanged();
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_details, menu);
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
}
